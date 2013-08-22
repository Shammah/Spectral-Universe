namespace Spectral.Graphics.Programs

import System
import OpenTK
import OpenTK.Graphics.OpenGL
import Spectral

class MVPProgram(GLProgram, ICameraObserver):
"""This is the most basic program we have that, which consists of basic MVP functionality."""

    Model as Matrix4:
    """
    Model matrix.
    Remarks: Private variable _mvChanged will be true.
    """
        get:
            return _model
        set:
            _model     = value
            _mvChanged = true

    View as Matrix4:
    """
    View matrix (camera).
    Remarks: Private variable _mvChanged will be true.
    """
        get:
            return _view
        set:
            _view      = value
            _mvChanged = true

    Projection as Matrix4:
    """
    Projection matrix.
    Remarks: Private variable _projChanged will be true.
    """
        get:
            return _projection
        set:
            _projection  = value
            _projChanged = true

    private _model as Matrix4
    private _projection as Matrix4
    private _view as Matrix4

    private _mvChanged as bool
    private _projChanged as bool

    private _mv_uniform as int
    private _proj_uniform as int
    private _norm_uniform as int

    def constructor():
    """Constructor."""
        super()

        _model          = Matrix4.Identity
        _projection     = Matrix4.Identity
        _view           = Matrix4.Identity

        _mvChanged      = true
        _projChanged    = true

    override def Link():
    """Compiles the shaders, then links the program together, and finally locates the uniform variables in the shader."""
        super.Link()

        # Once linked up, we can retrieve our uniform variables.
        _mv_uniform = GL.GetUniformLocation(Handle, "modelView")
        raise GLProgramException(self, "Unable to locate uniform shader variable 'modelView' in BasicShader'.") if (_mv_uniform == -1)

        _proj_uniform = GL.GetUniformLocation(Handle, "projection")
        raise GLProgramException(self, "Unable to locate uniform shader variable 'projection' in BasicShader'.") if (_proj_uniform == -1)

        _norm_uniform = GL.GetUniformLocation(Handle, "normalTransformation")
        raise GLProgramException(self, "Unable to locate uniform shader variable 'normalTransformation' in BasicShader'.") if (_norm_uniform == -1)

    override def Use():
    """Tells OpenGL to use this program. Updates uniform matrices if they have changed."""
        super()

        # Update the model-view (and the corresponding normal transformation) if needed.
        ModelViewUpdate(self) if _mvChanged

        # Only update the projection if needed, this saves unnecessary GL calls.
        ProjectionUpdate(self) if _projChanged

    virtual def OnOrientationChanged(camera as Camera):
        View = camera.LookAt()

    virtual def OnPerspectiveChanged(camera as Camera):
        Projection = camera.Perspective()

    virtual def OnOrthoChanged(camera as Camera):
        pass

    private def ModelViewUpdate(program as MVPProgram):
    """
    Updates the shader when the model or view has been updated.
    Param program: The program which model or view has changed.
    """
        # Only update if we have actually linked the program.
        if Linked:
            # Update the model-view (and the corresponding normal transformation) if needed.
            mv as Matrix4       = _model * _view
            norm as Matrix4     = Matrix4.Transpose(Matrix4.Invert(mv))
            GL.UniformMatrix4(_mv_uniform, false, mv)
            GL.UniformMatrix4(_norm_uniform, false, norm)
            _mvChanged          = false

    private def ProjectionUpdate(program as MVPProgram):
    """
    Updates the shader when the projection has been updated.
    Param program: The program which model or view has changed.
    """
        # Only update if we have actually linked the program.
        if Linked:
            proj as Matrix4     = Projection
            GL.UniformMatrix4(_proj_uniform, false, proj)
            _projChanged        = false