describe 'building filters while respecting context'
  describe 'when respect_context is true'
    before
      call unite#taskwarrior#config('respect_context', 1)
      call unite#taskwarrior#call(['context', 'c1'])
    end

    after
      call unite#taskwarrior#config#reset()
      call vimproc#system('rake reset')
    end

    it 'will create a filter with the context set'
      let obj = unite#taskwarrior#filters#new()
      Expect obj.str() == '( status.not:deleted ) and ( project.is:c1 )'
    end

    it 'given another context it will ignore current one'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.context('c2')
      Expect obj.str() == '( status.not:deleted ) and ( project.is:proj-1 )'
    end

    describe 'passing in ignore_context'
      it 'will ignore context if told to'
      let obj = unite#taskwarrior#filters#new({'ignore_context': 1})
      Expect obj.str() == '( status.not:deleted )'
      end
    end
  end

  describe 'when using global variables'
    before
      let g:unite_taskwarrior_respect_context = 1
      call unite#taskwarrior#call(['context', 'c1'])
    end

    after
      unlet g:unite_taskwarrior_respect_context
      call vimproc#system('rake reset')
    end

    it 'will create a filter with the context set'
      let obj = unite#taskwarrior#filters#new()
      Expect obj.str() == '( status.not:deleted ) and ( project.is:c1 )'
    end

    it 'given another context it will ignore current one'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.context('c2')
      Expect obj.str() == '( status.not:deleted ) and ( project.is:proj-1 )'
    end
  end

  describe 'when respect_context is false'
    before
      call unite#taskwarrior#config('respect_context', 0)
      call unite#taskwarrior#call(['context', 'c1'])
    end

    after
      call unite#taskwarrior#config#reset()
      call vimproc#system('rake reset')
    end

    it 'will create a filter with the context set'
      let obj = unite#taskwarrior#filters#new()
      Expect obj.str() == '( status.not:deleted )'
    end

    it 'given another context it will ignore current one'
      let obj = unite#taskwarrior#filters#new()
      let obj = obj.context('c2')
      Expect obj.str() == '( status.not:deleted ) and ( project.is:proj-1 )'
    end
  end
end
