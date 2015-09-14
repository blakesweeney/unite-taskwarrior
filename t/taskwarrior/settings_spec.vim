describe 'taskwarrior settings functions'
  before
    call vimproc#system('rake reset')
  end

  after
    call vimproc#system('rake reset')
  end

  describe 'getting the name'
    describe 'when we have to add rc.'
      it 'uses the given string if it starts with rc.'
        Expect unite#taskwarrior#settings#name('rc.bob') == 'rc.bob'
      end

      it 'will add an rc. if needed'
        Expect unite#taskwarrior#settings#name('bob') == 'rc.bob'
      end

      it 'will use the name of a dictonary'
        let val = unite#taskwarrior#settings#name({'name': 'bob'})
        Expect val == 'rc.bob'
      end

      it 'will not add an extra rc. name of a dictonary'
        let val = unite#taskwarrior#settings#name({'name': 'rc.bob'})
        Expect val == 'rc.bob'
      end
    end

    describe 'when we have to remove rc.'
      it 'strips rc. from the given string if it starts with rc.'
        Expect unite#taskwarrior#settings#name('rc.bob', 0) == 'bob'
      end

      it 'will use the given string if not rc.'
        Expect unite#taskwarrior#settings#name('bob', 0) == 'bob'
      end

      it 'will use the name of a dictonary'
        let val = unite#taskwarrior#settings#name({'name': 'bob'}, 0)
        Expect val == 'bob'
      end

      it 'will not add an extra rc. name of a dictonary'
        let val = unite#taskwarrior#settings#name({'name': 'rc.bob'}, 0)
        Expect val == 'bob'
      end
    end
  end

  describe 'getting a setting'
    it 'can get a setting'
      let ans = {'name': 'verbose', 'value': 'no'}
      Expect unite#taskwarrior#settings#get('verbose') == ans
    end

    it 'gives empty for unknown value'
      Expect unite#taskwarrior#settings#get('bob') == {}
    end
  end

  describe 'loading all settings'
    it 'can get a list'
      let settings = unite#taskwarrior#settings#load()
      Expect type(settings) == type([])
    end
  end

  describe 'setting a value'
    it 'can set a value'
      call unite#taskwarrior#settings#set('reserved.lines', 5)
      let ans = {'name': 'reserved.lines', 'value': '5'}
      Expect unite#taskwarrior#settings#get('reserved.lines') == ans
    end

    it 'can delete a setting'
      call unite#taskwarrior#settings#set('reserved.lines', '8')
      call unite#taskwarrior#settings#delete('reserved.lines')
      let ans = {}
      Expect unite#taskwarrior#settings#get('reserved.lines') == ans
    end

    it 'can set a value to blank'
      call unite#taskwarrior#settings#unset('reserved.lines')
      let ans = {'name': 'reserved.lines', 'value': '1'}
      Expect unite#taskwarrior#settings#get('reserved.lines') == ans
    end
  end
end
