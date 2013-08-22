namespace Universe.Actors

import System
import System.Collections.Generic
import OpenTK
import Spectral
import Spectral.Actors
import Spectral.Files
import Spectral.Graphics
import Spectral.Graphics.Textures
import Spectral.Graphics.Vertices
import Spectral.Physics.Collision

class GameMesh(Mesh):
"""All the meshes in our game will be .obj models with 1D textures."""
    
    # Each resource only gets loaded once in a dictionary.
    static protected _data as Dictionary[of string, (VertexNormal1D)] = Dictionary[of string, (VertexNormal1D)]()
    static protected _obbs as Dictionary[of string, BoundingBox] = Dictionary[of string, BoundingBox]()

    def constructor(name as string, resource as string, program as Spectral.Graphics.Programs.GLProgram):
    """
    Creates a mesh for our game.
    Param name: Name of the actor.
    Param resource: Name of the resource, without extension.
    Param program: The shader program the mesh will use.
    Raises NullReferenceException: program may not be null.
    """
        raise NullReferenceException("The mesh its program may not be null.") if program is null
        super(name, LoadModel(resource))

        Model.Texture   = Texture1D("./Resources/Textures/Game/$(resource).png")
        Model.Program   = program

        OBB = BoundingBox(_obbs[resource])

    private def LoadData(resource as string):
        file            = ObjReader("./Resources/Models/Game/$(resource).obj")
        vertices        = List[of VertexNormal1D]()

        v as (Vector3)  = Utility.AsVector3(file.Vertices)
        n as (Vector3)  = Utility.AsVector3(file.Normals)

        # Combines vertex information for a final list of vertices.
        for face in file.Faces:
            for i in range(0, len(face, 0)):
                vertices.Add(VertexNormal1D(v[face[i, 0] - 1], n[face[i, 1] - 1], 0.5f))

        _data[resource] = vertices.ToArray()
        _obbs[resource] = file.OBB

    private def LoadModel(resource as string) as IModel:
        LoadData(resource) unless _data.ContainsKey(resource)

        return Model[of VertexNormal1D](_data[resource])