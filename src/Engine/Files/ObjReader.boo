namespace Spectral.Files

import System
import System.IO
import System.Collections.Generic
import Boo.Lang.PatternMatching
import Spectral.Physics.Collision

class ObjReader:
"""Reads and parses WaveFront .obj 3D geometry files. Only triangles are supported."""

    enum FaceType:
    """We have different flavours of faces :)"""
        Vertex
        VertexTexture
        VertexTextureNormal
        VertexNormal

    Vertices as List[of (single)]:
    """Returns the list of vertices."""
        get:
            return _vertices

    TexCoords as List[of (single)]:
    """Returns the list of texture coordinates."""
        get:
            return _texCoords

    Normals as List[of (single)]:
    """Returns the list of normals."""
        get:
            return _normals

    Faces as List[of (uint, 2)]:
    """Returns the list of faces (indices)."""
        get:
            return _faces

    Type as FaceType:
    """Returns which type of faces this Obj files uses."""
        get:
            return _faceType

    OBB as BoundingBox:
    """Returns the bounding box of the model."""
        get:
            return _obb

    private _vertices as List[of (single)]
    private _texCoords as List[of (single)]
    private _normals as List[of (single)]
    private _faces as List[of (uint, 2)]
    private _faceType as FaceType
    private _detectFaceType as bool

    private _min_x as single
    private _min_y as single
    private _min_z as single

    private _max_x as single
    private _max_y as single
    private _max_z as single

    private _obb as BoundingBox
    
    def constructor(path as string):
    """
    Constructor, which reads and parses the .obj file.
    Param path: Path the the model file.
    Raises IOException: Any issue regarding the file reading itself.
    """
        _vertices       = List[of (single)]()
        _texCoords      = List[of (single)]()
        _normals        = List[of (single)]()
        _faces          = List[of (uint, 2)]()
        _faceType       = FaceType.Vertex
        _detectFaceType = true

        _min_x = _min_y = _min_z = _max_x = _max_y = _max_z = 0

        Parse(path)

        position = OpenTK.Vector3((_max_x - _min_x) / 2f, (_max_y - _min_y) / 2f, (_max_z - _min_z) / 2f)
        _obb = BoundingBox(position, _max_x - _min_x, _max_y - _min_y, _max_z - _min_z)

    private def Parse(path as string):
    """
    Param path: Path the the model file.
    Raises IOException: Any issue regarding the file reading itself.
    Todo: Add proper exception throwing.
    """
        using reader = File.OpenText(path):
            line as string
            tokens as (string)

            # Parse each line seperately.
            while ((line = reader.ReadLine()) is not null):
                tokens = line.Split(char(' '))

                match tokens[0]:
                    case "v":
                        ParseVertex(tokens)

                    case "vt":
                        ParseTexture(tokens)

                    case "vn":
                        ParseNormal(tokens)

                    case "f":
                        ParseFace(tokens)

                    # Skip line if not valid or parseable
                    otherwise:
                        pass

    private def ParseVertex(tokens as (string)):
    """
    Parses a vertex, with an optional 4th component.
    Param tokens: The tokens of the line.
    """
        x = Single.Parse(tokens[1])
        y = Single.Parse(tokens[2])
        z = Single.Parse(tokens[3])

        try:
            w = Single.Parse(tokens[4])
            _vertices.Add((x, y, z, w))
        except:
            _vertices.Add((x, y, z))

        # Register min & max values for bounding boxes.
        _min_x = x if x < _min_x
        _min_y = y if y < _min_y
        _min_z = z if z < _min_z

        _max_x = x if x > _max_x
        _max_y = y if y > _max_y
        _max_z = z if z > _max_z

    private def ParseTexture(tokens as (string)):
    """
    Parses texture coordinates, either 1D, 2D or 3D.
    Param tokens: The tokens of the line.
    """
        r = Single.Parse(tokens[1])

        try:
            s = Single.Parse(tokens[2])
            
            try:
                t = Single.Parse(tokens[3])
                _texCoords.Add((r, s, t))
            except:
                _texCoords.Add((r, s))
        except:
            # We only have 1 element, but because of the typing it has to be in an array.
            r_array    = array(single, 1)
            r_array[0] = r
            _texCoords.Add(r_array)

    private def ParseNormal(tokens as (string)):
    """
    Parses a normal, which always consists of 3 components.
    Param tokens: The tokens of the line.
    """
        x = Single.Parse(tokens[1])
        y = Single.Parse(tokens[2])
        z = Single.Parse(tokens[3])
        
        _normals.Add((x, y, z))

    private def ParseFace(tokens as (string)):
    """
    Parses a face. I am going to assume that faces come last, before vertices, normals and whatsoever.
    Each face token may consist of 3 or 2 seperate tokens itself.
    Param tokens: The tokens of the line.
    """
        face as (uint, 2)

        # Onetime facetype checking.
        if _detectFaceType:
            _faceType = DetectFaceType(tokens[1])
            _detectFaceType = false

        verticesPerFace = tokens.Length - 1

        # Allocate some memory according to the found facetype
        match Type:
            case FaceType.Vertex:
                face = matrix(uint, verticesPerFace, 1)
            case FaceType.VertexTexture:
                face = matrix(uint, verticesPerFace, 2)
            case FaceType.VertexNormal:
                face = matrix(uint, verticesPerFace, 2)
            case FaceType.VertexTextureNormal:
                face = matrix(uint, verticesPerFace, 3)

        # Parse each face component
        for i in range(1, verticesPerFace + 1):
            faceTokens = tokens[i].Split(char('/'))

            # Parse vertex.
            face[i - 1, 0] = UInt32.Parse(faceTokens[0])

            # Parse either texture or normal.
            face[i - 1, 1] = UInt32.Parse(faceTokens[1]) if Type == FaceType.VertexTexture or Type == FaceType.VertexTextureNormal
            face[i - 1, 1] = UInt32.Parse(faceTokens[2]) if Type == FaceType.VertexNormal

            # Parse definite normal.
            face[i - 1, 2] = UInt32.Parse(faceTokens[2]) if Type == FaceType.VertexTextureNormal

            _faces.Add(face)

    private def DetectFaceType(token as string) as FaceType:
    """
    Detects the facetype for a given face token.
    Raises ArgumentException: Unsupported face type.
    """
        split = token.Split(char('/')) # We need to split once for some analyzation regarding memory allocation.

        match split.Length:
            case 1:
                return FaceType.Vertex
                
            case 2:
                return FaceType.VertexTexture
                
            case 3:
                if split[1] == String.Empty: # v//vn has length 3, but the middle one (texture) is empty.
                        return FaceType.VertexNormal
                    else:
                        return FaceType.VertexTextureNormal

            otherwise:
                raise ArgumentException("Face has more than 3 components or is empty.")