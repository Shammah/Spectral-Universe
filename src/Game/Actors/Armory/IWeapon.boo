namespace Universe.Armory

interface IWeapon:
"""Basic interface for any weapon."""

    Ammo as uint:
    """The ammo of the weapon should be gettable and settable."""
        get
        set

    Owner as Spectral.Actors.Actor:
    """The owner of the weapon."""
        get
        set

    def Fire() as Projectile
    """
    Fires the weapon.
    Returns: A reference to the projectile if it was spawned and able to fire, else null.
    """