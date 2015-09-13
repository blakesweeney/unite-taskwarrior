describe 'building a string'
  describe 'single components'
    it 'ors together the tags'
      let obj = unite#taskwarrior#filters#new({'ignore_filter': 1})
      let obj = obj.tags(['+a', '+b'])
      Expect obj.str() == '( +a or +b )'
    end

    it 'ors together projects'
      let obj = unite#taskwarrior#filters#new({'ignore_filter': 1})
      let obj = obj.projects(['a', 'b'])
      Expect obj.str() == '( project.is:a or project.is:b )'
    end

    it 'and togethers filters'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.raw('date.is:today')
      Expect obj.str() == '( status.not:deleted and date.is:today )'
    end
  end

  describe 'for contexts'
    before
      call vimproc#system('rake reset')
    end

    it 'expands context'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.context('@c1')
      Expect obj.str() == '( status.not:deleted ) and ( project.is:c1 )'
    end

    it 'expands @ to current'
      call vimproc#system('task context c1')
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.context('@')
      Expect obj.str() == '( status.not:deleted ) and ( project.is:c1 )'
    end
  end

  describe 'given several things'
    it 'can build a filter'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.projects(['a', 'b'])
      let obj = obj.tags(['+a', '+b'])
      let ans = '( project.is:a or project.is:b ) and ( +a or +b ) and ( status.not:deleted )'
      Expect obj.str() == ans
    end

    it 'ands in the context'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.projects(['a', 'b'])
      let obj = obj.tags(['+a', '+b'])
      let obj = obj.context('@c1')
      let ans = '( project.is:a or project.is:b ) and ( +a or +b ) and ( status.not:deleted ) and ( project.is:c1 )'
      Expect obj.str() == ans
    end
  end

end
