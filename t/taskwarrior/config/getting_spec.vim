describe 'getting configuration values'
  before
    call unite#taskwarrior#config#reset()
  end

  it 'can get given a short name'
    Expect 'task' == unite#taskwarrior#config#get('command')
  end

  it 'can get given a long name'
    Expect 'task' == unite#taskwarrior#config#get('unite_taskwarrior_command')
  end

  it 'can get a value that was set with a call'
    call unite#taskwarrior#config#set('command', 'run')
    Expect 'run' == unite#taskwarrior#config#get('command')
  end

  it 'can get a nested value with .'
    call unite#taskwarrior#config#set({'status_mapping': { 'active': 'B' } })
    Expect unite#taskwarrior#config#get('status_mapping.active') == 'B'
  end

  describe 'from variables'
    it 'can get a value that was set with a global variable'
      let g:unite_taskwarrior_command = 'bob'
      Expect 'bob' == unite#taskwarrior#config#get('command')
      unlet g:unite_taskwarrior_command
    end

    it 'can get a value from a buffer variable'
      let b:unite_taskwarrior_command = 'bob'
      Expect 'bob' == unite#taskwarrior#config#get('command')
      unlet b:unite_taskwarrior_command
    end

    it 'prefers buffer over global'
      let b:unite_taskwarrior_command = 'steve'
      let g:unite_taskwarrior_command = 'bob'
      call unite#taskwarrior#config#set('command', 'run')
      Expect 'steve' == unite#taskwarrior#config#get('command')
      unlet g:unite_taskwarrior_command
      unlet b:unite_taskwarrior_command
    end

    it 'prefers a value set by global variables over call'
      let g:unite_taskwarrior_command = 'bob'
      call unite#taskwarrior#config#set('command', 'run')
      Expect 'bob' == unite#taskwarrior#config#get('command')
      unlet g:unite_taskwarrior_command
    end
  end

  describe 'getting the current configuration'
    it 'will respect set variables'
      let g:unite_taskwarrior_command = 'bob'
      let current = unite#taskwarrior#config#current()
      Expect current.command == 'bob'
      unlet g:unite_taskwarrior_command
    end

    it 'modifying the dictonary does not alter the configuration'
      let current = unite#taskwarrior#config#current()
      let current.command = 'other'
      Expect unite#taskwarrior#config#get('command') == 'task'
    end
  end

  describe 'with things that must be expanded'
    it 'expands the note directory'
      call unite#taskwarrior#config#set('note_directory', '~/.notes')
      Expect expand('~/.notes') == unite#taskwarrior#config#get('note_directory')
    end

    it 'will expand wiki root'
      call unite#taskwarrior#config#set('wiki_root', '~/bob/other')
      Expect unite#taskwarrior#config#get('wiki_root') == $HOME . '/bob/other'
    end
  end

end
