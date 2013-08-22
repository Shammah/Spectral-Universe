namespace Spectral.Test

import System
import Xunit
import Spectral.Actors

class ActorGroupTest():

    private ag as ActorGroup

    def constructor():
        ag = ActorGroup()
        ag.Add(PointLight("a1"))
        ag.Add(PointLight("a2"))

        ag2 = ActorGroup()
        ag2.Add(PointLight("a3"))
        ag2.Add(PointLight("a4"))
        ag2.Add(PointLight("a5"))

        ag3 = ActorGroup()
        ag3.Add(PointLight("a6"))

        ag4 = ActorGroup()

        ag3.Add("subsubsubgroup", ag4)
        ag2.Add("subsubgroup", ag3)
        ag.Add("subgroup", ag2)

    [Fact]
    def Count():
        Assert.Equal(6, ag.Count)

    [Fact]
    def NullActor():
        func as Assert.ThrowsDelegate = { ag.Add(null) }
        Assert.Throws[of System.NullReferenceException](func)

    [Fact]
    def NullGroup():
        func as Assert.ThrowsDelegate = { ag.Add("group", null) }
        Assert.Throws[of System.NullReferenceException](func)

    [Fact]
    def EmptyGroupName():
        func as Assert.ThrowsDelegate = { ag.Add("", ActorGroup()) }
        Assert.Throws[of System.ArgumentException](func)

    [Fact]
    def NullActorRemove():
        func as Assert.ThrowsDelegate = { ag.Remove(null) }
        Assert.Throws[of System.NullReferenceException](func)

    [Fact]
    def IteratorTest():
        i = 1
        for actor as Actor in ag:
            Assert.Equal("a" + i, actor.Name)
            i++

    [Fact]
    def CopyTo():
        ar = (PointLight("b1"), PointLight("b2"), PointLight("b3"), PointLight("b4"), PointLight("b5"))

        ag.CopyTo(ar, 2)

        Assert.Equal("b1", ar[0].Name)
        Assert.Equal("b2", ar[1].Name)
        Assert.Equal("a1", ar[2].Name)
        Assert.Equal("a2", ar[3].Name)
        Assert.Equal("a3", ar[4].Name)