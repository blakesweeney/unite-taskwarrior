describe 'building a task object'
  describe 'parsing output formats'

    it 'can parse JSON per line output'
      let file = join(readfile('./t/examples/json-no-array'), "\n")
      let obj = unite#taskwarrior#parse(file)
      Expect len(obj) == 4
    end

    it 'can parse an array'
      let file = join(readfile('./t/examples/json-array'), "\n")
      Expect 4 == len(unite#taskwarrior#parse(file))
    end

    it 'can parse output from version 2.4.5'
      let file = join(readfile('./t/examples/json-2.4'), "\n")
      Expect 1 == len(unite#taskwarrior#parse(file))
    end

    it 'can handle bad input message from taskwarrior'
      Expect {} == unite#taskwarrior#parse('The')
    end

    it 'can parse empty output'
      Expect {} == unite#taskwarrior#parse('')
    end
  end

  describe 'setting comptued values'

    it 'loads properties and computes data'
      let ans = {
            \ "id": 182,
            \ "area": "$.work",
            \ "description": "7:30 clean St Petes downstairs",
            \ "due": "20150812T050000Z",
            \ "duration": "30min",
            \ "entry": "20150811T215530Z",
            \ "imask": 31,
            \ "modified": "20150804T032755Z",
            \ "need": "2",
            \ "parent": "54970203-8725-45a8-a700-aeecac453250",
            \ "recur": "weekly",
            \ "status": "pending",
            \ "tags": [ "StP", "time" ],
            \ "uuid": "43dd7a4e-cc2c-42e1-ad5a-303a38e71640",
            \ "urgency": 10.9581,
            \ 'short': '43dd7a4e',
            \ 'note': expand('~/.task/note/43dd7a4e.mkd'),
            \ 'uri': '<task:43dd7a4e-cc2c-42e1-ad5a-303a38e71640>',
            \ 'depends': [],
            \ 'annotations': [],
            \ 'started': 0,
            \ 'stopped': 1,
            \ 'project': '',
            \ 'start_time': '',
            \ 'stop_time': ''
            \ }
      let file = join(readfile('./t/examples/json-2.4'), "\n")
      let obj = unite#taskwarrior#parse(file)
      Expect [ans] == obj

    end
  end
end
