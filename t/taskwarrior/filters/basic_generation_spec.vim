describe 'Creating a simple filter'
  describe 'for only projects'
    it 'can handle a single project'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.projects('a')
      Expect obj._projects == ['a']
    end

    it 'can infer the project from directory'
      let obj = unite#taskwarrior#filters#new({'infer_project': 1})
      let here = fnamemodify(getcwd(), ":t")
      Expect obj._projects == [here]
    end

    it 'can handle being given several projects'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.projects('a')
      let obj = obj.projects('b')
      Expect obj._projects == ['a', 'b']
    end

    it 'can handle being given a list of projects'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.projects(['a', 'b'])
      Expect obj._projects == ['a', 'b']
    end
  end

  describe 'for only tags'
    it 'can build a simple filter'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.tags('+a')
      Expect obj._tags == ['+a']
    end
  end

  describe 'for contexts'
    " it 'will set the context'
    "   let obj = unite#taskwarrior#filters#new()
    "   let obj = obj.context('@a')
    "   Expect obj.context == '@a'
    " end

    " it 'will only use the last set context'
    "   let obj = unite#taskwarrior#filters#new()
    "   let obj = obj.context('@a')
    "   let obj = obj.context('@b')
    "   Expect obj.context == '@b'
    " end

"     it 'will use the last set one given a list'
"       let obj = unite#taskwarrior#filters#new()
"       let obj = obj.context(['@1', '@a'])
"       Expect obj.context == '@a'
    " end
  end

  describe 'for a raw filter'
    it 'will use the configured filter'
      let obj = unite#taskwarrior#filters#new()
      Expect obj._raw == ['status.not:deleted']
    end

    it 'will not use configured filter if told not to'
      let obj = unite#taskwarrior#filters#new({'ignore_filter': 1})
      Expect obj._raw == []
    end

    it 'will store the filter'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.raw('date.is:today or another')
      Expect obj._raw == ['status.not:deleted', 'date.is:today or another']
    end
  end

  describe 'for several things'
    it 'can build a filter for several'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.projects(['a', 'b'])
      let obj = obj.tags('+a')
      Expect obj._tags == ['+a']
      Expect obj._projects == ['a', 'b']
    end
  end

  describe 'with options'
    it 'will set the tags'
      let obj = unite#taskwarrior#filters#new({'tags': '+a'})
      Expect obj._tags == ['+a']
    end

    it 'will set the project'
      let obj = unite#taskwarrior#filters#new({'projects': 'a'})
      Expect obj._projects == ['a']
    end
  end
end
