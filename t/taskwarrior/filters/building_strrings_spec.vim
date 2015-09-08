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

  describe 'given several things'
    it 'can build a filter'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.projects(['a', 'b'])
      let obj = obj.tags(['+a', '+b'])
      let ans = '( project.is:a or project.is:b ) and ( +a or +b ) and ( status.not:deleted )'
      Expect obj.str( ) == ans
    end
  end
end
