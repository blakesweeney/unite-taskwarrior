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

  describe 'loading all contexts'
    it 'can gets them all including none'
      let contexts = unite#taskwarrior#context#select()
      Expect len(contexts) == 2
    end

    it 'gets the all data as well as count'
      let contexts = unite#taskwarrior#context#select()
      let ans = [
            \ {'status': 'active', 'name': 'none', 'definition': '', 'count': 4},
            \ {'status': 'inactive', 'name': 'c1', 'definition': 'project.is:c1', 'count': 0}]
      Expect contexts == ans
    end
  end

end
