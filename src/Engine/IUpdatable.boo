namespace Spectral

interface IUpdatable:
"""Entities that can be updates with time intervals."""
    
    def Update(elapsedTime as single)