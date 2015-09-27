describe 'setting values'
  before
    call unite#taskwarrior#config#reset()
  end
  
  after
    call unite#taskwarrior#config#reset()
  end

  describe 'it can set a value'
    call unite#taskwarrior#config#set('command', 'A')
    Expect unite#taskwarrior#config#get('command') == 'A'
  end

  " describe 'nested values'
    " it 'can set a value with .'
    "   call unite#taskwarrior#config#set('status_mapping.active', 'A')
    "   let val = unite#taskwarrior#config#get('status_mapping')
    "   Expect val.active == 'A'
    " end

    " it 'will not alter the other values'
    "   call unite#taskwarrior#config#set('status_mapping.active', 'A')
    "   let val = unite#taskwarrior#config#get('status_mapping')
    "   Expect val.active_context == '@'
    " end
  " end

  describe 'using dictonaries'

    it 'can be configured with a dictonary in a call'
      call unite#taskwarrior#config#set({
            \ 'command': 'something',
            \ 'note_directory': '~/.task/bob'
            \ })
      Expect unite#taskwarrior#config#get('command') == 'something'
    end

    it 'uses changes nothing if given empty dictonary'
      let current = unite#taskwarrior#config#current()
      call unite#taskwarrior#config#set({})
      Expect unite#taskwarrior#config#current() == current
    end

    it 'keeps default values that were not set'
      call unite#taskwarrior#config#set({
            \ 'command': 'something',
            \ 'note_directory': '~/.task/bob'
            \ })
      Expect unite#taskwarrior#config#get('note_suffix') == 'mkd'
    end
  end

  describe 'resetting values'
    it 'can reset a config with config#reset'
      call unite#taskwarrior#config#set('command', 'other')
      call unite#taskwarrior#config#reset()
      Expect unite#taskwarrior#config#get('command') == 'task'
    end

    it 'can reset given a single key'
      call unite#taskwarrior#config#set('command', 'other')
      call unite#taskwarrior#config#reset('command')
      Expect unite#taskwarrior#config#get('command') == 'task'
    end

    it 'can reset given several keys'
      call unite#taskwarrior#config#set('command', 'other')
      call unite#taskwarrior#config#set('annotation_precision', 4)
      call unite#taskwarrior#config#reset('command', 'annotation_precision')
      Expect unite#taskwarrior#config#get('command') == 'task'
      Expect unite#taskwarrior#config#get('annotation_precision') == 2
    end

    it 'can reset given a list of keys'
      call unite#taskwarrior#config#set('command', 'other')
      call unite#taskwarrior#config#set('annotation_precision', 4)
      call unite#taskwarrior#config#reset(['command', 'annotation_precision'])
      Expect unite#taskwarrior#config#get('command') == 'task'
      Expect unite#taskwarrior#config#get('annotation_precision') == 2
    end
  end
end
