namespace Universe.Actors

class Armor:
"""An armor class, very basic but might be extended later on."""
    
    Charge as uint:
    """How much charge there is left in the armor."""
        get:
            return _charge
        set:
            _charge = value

    private _charge as uint

    def constructor(charge as uint):
    """
    Constructor.
    Param charge: The initial charge of the armor.
    """
        Charge = charge