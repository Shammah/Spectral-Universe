namespace Universe

import Spectral.Actors
import Spectral.Graphics

class TerrainMesh(Mesh):
"""A mesh that has addition information about the transformation used to generate it."""

    Transformation as Transformation:
    """The transformation data used to generate the mesh."""
        get:
            return _transformation

    private _transformation as Transformation
    
    def constructor(name as string, model as IModel, transformation as Transformation):
    """
    Constructor.
    Param name: Name of the actor.
    Param model: The model of the mesh.
    Param transformation: The transformation data used to generate the mesh.
    """
        super(name, model)

        _transformation = transformation