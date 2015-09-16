describe 'taskwiki integration'
  describe 'finding the wiki directory'
    it 'defaults to ~/vimwiki'
      Expect unite#taskwarrior#taskwiki#base() == $HOME . '.vim/wiki'
    end
  end

  describe 'finding wiki filenames'
    it 'can find an annotated absolute filename'
      let task = {'annotations': [
            \ {'description': 'bob'}, 
            \ {'description': 'wiki: /somewhere/else/../bob/index.html'}]}
      let ans = '/somewhere/else/../bob/index.html'
      Expect unite#taskwarrior#taskwiki#filename(task) == ans
    end

    it 'can find an annotated relative filename'
      let task = {'annotations': [
            \ {'description': 'bob'}, 
            \ {'description': 'wiki: somewhere/else'}]}
      Expect unite#taskwarrior#taskwiki#filename(task) == 'somewhere/else'
    end

    it 'can find a filename using a project'
      let task = {'project': 'bob'}
      let ans = $HOME . '.vim/wiki/project/bob.project.wiki'
      Expect unite#taskwarrior#taskwiki#filename(task) == ans
    end

    it 'will use index file if no project or annotation exists'
      let task = {'annotations': [{'description': 'bob'}]}
      let ans = $HOME . '.vim/wiki/index.wiki'
      Expect unite#taskwarrior#taskwiki#filename(task) == ans
    end
end
