describe 'context functions'
  describe 'getting a context by name'
    it 'can get a context by name'
      let context = unite#taskwarrior#context#get('c1')
      Expect context == {'name': 'c1', 'definition': 'project.is:c1'}
    end

    it 'gives empty for missing context'
      Expect unite#taskwarrior#context#get('bob') == {}
    end
  end

  describe 'getting the current context'
    before
      call vimproc#system('rake reset')
    end

    it 'can get the current context'
      call vimproc#system('task context c1')
      Expect unite#taskwarrior#context#current() == {'name': 'c1', 'definition': 'project.is:c1'}
    end

    it 'will get nothing if no current'
      Expect unite#taskwarrior#context#current() == {}
    end
  end

  describe 'creating a context'
    before
      call vimproc#system('rake reset')
    end

    describe 'with a current context'
      before
        call unite#taskwarrior#call(['context', 'c2'])
      end

      it 'has the current current context'
      Expect unite#taskwarrior#context#current().name == 'c2'
      end

      it 'can create a filter'
        let c = {'name': 'c1', 'definition': 'project.is:c1'}
        let filt = unite#taskwarrior#context#filter(c)
        Expect filt == '( status.not:deleted ) and ( project.is:c1 )'
      end
    end

    describe 'without a set context'
      it 'can create a filter'
        let c = {'name': 'c1', 'definition': 'project.is:c1'}
        let filt = unite#taskwarrior#context#filter(c)
        Expect filt == '( status.not:deleted ) and ( project.is:c1 )'
      end
    end
  end

  describe 'loading all contexts'
    it 'can gets them all including none'
      let contexts = unite#taskwarrior#context#select()
      Expect len(contexts) == 3
    end

    it 'gets the all data as well as count'
      let contexts = unite#taskwarrior#context#select()
      let ans = [
            \ {'status': 'active', 'name': 'none', 'definition': '', 'count': 4},
            \ {'status': 'inactive', 'name': 'c1', 'definition': 'project.is:c1', 'count': 0},
            \ {'status': 'inactive', 'name': 'c2', 'definition': 'project.is:proj-1', 'count': 0}]
      Expect contexts == ans
    end
  end

end
