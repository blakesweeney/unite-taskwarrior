describe 'getting a formatter'
  before
    call unite#taskwarrior#config#reset()
  end

  describe 'for tasks'
    it 'defaults to simple'
      Expect unite#taskwarrior#config#get('formatter') == 'unite#taskwarrior#formatters#simple'
    end

    it 'will use the given formatter'
      call unite#taskwarrior#config#set('formatter', 'a')
      Expect unite#taskwarrior#config#get('formatter') == 'a'
    end

    it 'will use default formatter if g:unite_taskwarrior_use_taskwiki set'
      let g:unite_taskwarrior_use_taskwiki = 1
      Expect unite#taskwarrior#config#get('formatter') == 'unite#taskwarrior#formatters#simple'
      unlet g:unite_taskwarrior_use_taskwiki
    end

    it 'will use default formatter if use_taskwiki set in config'
      call unite#taskwarrior#config#set('use_taskwiki', 1)
      Expect unite#taskwarrior#config#get('formatter') == 'unite#taskwarrior#formatters#simple'
    end
  end

  describe 'for notes'
    it 'defaults to description'
      let ans = 'unite#taskwarrior#formatters#simple'
      Expect unite#taskwarrior#config#get('note_formatter') == ans
    end

    it 'will get the set note formatter'
      call unite#taskwarrior#config#set('note_formatter', 'bob')
      Expect unite#taskwarrior#config#get('note_formatter') == 'bob'
    end

    it 'will use taskwiki if global is set'
      let g:unite_taskwarrior_use_taskwiki = 1
      let ans = 'unite#taskwarrior#formatters#taskwiki'
      Expect unite#taskwarrior#config#get('note_formatter') == ans
      unlet g:unite_taskwarrior_use_taskwiki
    end

    it 'will use taskwiki if config is set'
      call unite#taskwarrior#config#set('use_taskwiki', 1)
      let ans = 'unite#taskwarrior#formatters#taskwiki'
      Expect unite#taskwarrior#config#get('note_formatter') == ans
    end
  end
end
