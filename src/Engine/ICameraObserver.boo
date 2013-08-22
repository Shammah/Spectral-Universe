namespace Spectral

interface ICameraObserver():
"""An entity that can respond to camera events."""
    
    def OnOrientationChanged(camera as Camera)
    """Called when the camera orientation has changed."""

    def OnPerspectiveChanged(camera as Camera)
    """Called  when the camera projection has changed."""

    def OnOrthoChanged(camera as Camera)
    """Called when the camera orthogonal view has changed."""