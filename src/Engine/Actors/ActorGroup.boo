namespace Spectral.Actors

import System
import System.Linq
import System.Collections.Generic

class ActorGroup(IDisposable, System.Collections.ICollection):
"""A group of actors that acts like a category (with possible sub-categories)."""
    
    Actors as Dictionary[of string, Actor]:
    """Returns the dictionary of actors for this group, excluding the subgroups."""
        get:
            return _actors

    Groups as Dictionary[of string, ActorGroup]:
    """Returns the dictionary that will hold all the subgroups of this group."""
        get:
            return _subGroups

    Count as int:
    """Returns the total number of actors (recursively)."""
        get:
            sum = 0

            for g in Groups.Values:
                sum += g.Count

            return sum + Actors.Count

    SyncRoot as object:
    """Returns the lock object."""
        get:
            return _syncRoot

    IsSynchronized as bool:
    """Returns whether the synclock is currently in use or not (threadsafe)."""
        get:
            locked = System.Threading.Monitor.TryEnter(SyncRoot)

            if locked:
                System.Threading.Monitor.Exit(SyncRoot)
                return false
            else:
                return true

    private _actors as Dictionary[of string, Actor]
    private _subGroups as Dictionary[of string, ActorGroup]

    private _syncRoot as object
    private _disposed as bool

    def constructor():
    """Constructor."""
        _actors     = Dictionary[of string, Actor]()
        _subGroups  = Dictionary[of string, ActorGroup]()
 
        _syncRoot   = System.Object()
        _disposed   = false

    def Add(actor as Actor):
    """
    Tries to add an actor to the group or one of its subgroup.
    Raises NullReferenceException: The actor cannot be null.
    Todo: /filesystem/implementation/yay/.
    """
        raise NullReferenceException("The actor cannot be null.") if actor is null
        Actors.Add(actor.Name, actor)

    def Add(path as string, group as ActorGroup):
    """
    Tries to add an ActorGroup to the group or one of its subgroup.
    Raises ArgumentException: The path cannot be empty.
    Raises NullReferenceException: Group cannot be null.
    Todo: /filesystem/implementation/yay/.
    """
        raise ArgumentException("The path cannot be empty.") if path == String.Empty
        raise NullReferenceException("The group cannot be null.") if group is null
        Groups.Add(path, group)

    def Remove(actor as Actor):
    """
    Tries to remove an actor or ActorGroup from the group or one of its subgroup.
    Raises NullReferenceException: The actor cannot be null.
    Todo: /filesystem/implementation/yay/.
    """
        raise NullReferenceException("The actor cannot be null.") if actor is null
        Actors.Remove(actor.Name) if Actors.ContainsKey(actor.Name)

    def GetEnumerator() as System.Collections.IEnumerator:
    """Returns an enumerator to enumerate between all actors (and subgroups)."""
        return ToList(self, true).GetEnumerator()

    def CopyTo(ar as System.Array, index as int):
        list = ToList(self, true)

        counter = 0
        for i in range(index, ar.Length):
            ar[i] = list[counter]
            counter++

    static def ToList(pwd as ActorGroup, recursive as bool) as List[of Actor]:
    """
    Transforms an ActorGroup into a List.
    Param pwd: The current ActorGroup the create the list from.
    Param recursive: Whether to include actors in the subgroups or not.
    Returns: A list of all actors.
    """
        list = List[of Actor]()

        if recursive:
            ToListRecursive(list, pwd)
        else:
            # Only add actors of the current list pwd.
            for actor in pwd.Actors.Values:
                list.Add(actor)

        return list


    static private def ToListRecursive(ref list as List[of Actor], pwd as ActorGroup):
        # Add all actors of the pwd.
        for actor in pwd.Actors.Values:
            list.Add(actor)

        # Add all actors from the subgroups of the pwd.
        for group in pwd.Groups.Values:
            ToListRecursive(list, group)

    def Dispose():
    """Cleanup up the actors and the subgroups."""
        return if _disposed

        for actor in Actors.Values.ToList():
            actor.Destroy()

        for group in Groups.Values:
            group.Dispose() if group is not null

        _disposed = true