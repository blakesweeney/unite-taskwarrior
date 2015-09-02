scriptencoding utf-8

describe 'Formatting'
  describe 'with the simple formatter'
    it 'can handle a simple task'
      let task = {
            \ 'description': 'A description',
            \ 'project': 'bob',
            \ 'tags': ['one', 'two'],
            \ 'status': 'pending'
            \ }
      let options = {'project': 3}
      let ans = '[ ] bob A description                                                   :one:two:'
      Expect ans == unite#taskwarrior#formatters#simple(task, options)
    end

    it 'will use given max project size for formatting'
      let task = {
            \ 'description': 'A description',
            \ 'project': 'bob',
            \ 'tags': ['one', 'two'],
            \ 'status': 'pending'
            \ }
      let options = {'project': 5}
      let ans = '[ ] bob   A description                                                 :one:two:'
      Expect ans == unite#taskwarrior#formatters#simple(task, options)
    end

    it 'defaults to a project of 10'
      let task = {
            \ 'description': 'A description',
            \ 'project': 'bob',
            \ 'tags': ['one', 'two'],
            \ 'status': 'pending'
            \ }
      let ans = '[ ] bob        A description                                            :one:two:'
      Expect unite#taskwarrior#formatters#simple(task) == ans
    end

    it 'will truncate an overly long description'
      let task = {
            \ 'description': 'A description A description A description A description A description A description A description A description ',
            \ 'project': 'bob',
            \ 'tags': ['one', 'two'],
            \ 'status': 'pending'
            \ }
      let ans = '[ ] bob        A description A description A description A description  :one:two:'
      Expect unite#taskwarrior#formatters#simple(task) == ans
    end
  end

  describe 'with the taskwarrior formatter'
    it 'can handle a simple task'
      let task = {
            \ 'description': 'A description',
            \ 'project': 'bob',
            \ 'tags': ['one', 'two'],
            \ 'status': 'pending',
            \ 'short': 'd5e6eb1c',
            \ }
      let ans = '* [ ] A description  #d5e6eb1c'
      Expect unite#taskwarrior#formatters#taskwiki(task) == ans
    end

    it 'can add an optional date'
      let task = {
            \ 'description': 'A description',
            \ 'project': 'bob',
            \ 'tags': ['one', 'two'],
            \ 'status': 'pending',
            \ 'short': 'd5e6eb1c',
            \ 'due': '20150801T035959Z'
            \ }
      let ans = '* [ ] A description(2015-08-01 03:59)  #d5e6eb1c'
      Expect unite#taskwarrior#formatters#taskwiki(task) == ans
    end

    it 'can handle a date with no time'
      let task = {
            \ 'description': 'A description',
            \ 'project': 'bob',
            \ 'tags': ['one', 'two'],
            \ 'status': 'pending',
            \ 'short': 'd5e6eb1c',
            \ 'due': '20150801T000000Z'
            \ }
      let ans = '* [ ] A description(2015-08-01)  #d5e6eb1c'
      Expect unite#taskwarrior#formatters#taskwiki(task) == ans
    end

  end
end
