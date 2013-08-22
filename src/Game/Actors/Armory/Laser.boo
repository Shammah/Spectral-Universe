namespace Universe.Armory

class Laser(IWeapon):
"""A laser that shoots pewpew hot colorful lines."""

    Ammo as uint:
        get:
            return _ammo
        set:
            _ammo = value

    Owner as Spectral.Actors.Actor:
    """The owner of the weapon."""
        get:
            return _owner
        set:
            _owner = value

    private _ammo as uint
    private _owner as Spectral.Actors.Actor

    def constructor(owner as Spectral.Actors.Actor):
    """Constructor."""
        self(owner, 100)

    def constructor(owner as Spectral.Actors.Actor, ammo as uint):
    """
    Constructor.
    Param owner: The owner of the weapon.
    Param ammo: The amount of ammo the laser will have.
    """
        _owner = owner
        _ammo = ammo

    def Fire() as Projectile:
    """
    If there is ammo, it creates a laser ray.
    Returns: A reference to the created ray.
    """
        # No ammo too shoot with :(
        if Ammo <= 0:
            return null

        _ammo --
        return LaserPewPew(Owner)