describe 'the sorter_task filter'
  describe 'getting the definition'
    after
      call unite#taskwarrior#config#reset()
    end

    it 'can get the given definition'
      let context = {'custom_sorting': 'due+'}
      let def = unite#filters#sorter_task#get_sorting_definition(context)
      Expect def == 'due+'
    end

    it 'can get the definition by given name'
      call unite#taskwarrior#config#set('sort_orders', {'L': 'due+', 'P': 'due+,project-'})
      let context = {'custom_sorting': 'P'}
      let def = unite#filters#sorter_task#get_sorting_definition(context)
      Expect def == 'due+,project-'
    end

    it 'defaults to the default filter'
      call unite#taskwarrior#config#set('default_ordering', 'project+')
      let def = unite#filters#sorter_task#get_sorting_definition({})
      Expect def == 'project+'
    end
  end

  describe 'building the sorter'
    it 'can get all attributes'
      let context = {'custom_sorting': 'due+,project-,urgency+'}
      let val = unite#filters#sorter_task#build(context)
      Expect len(val.attrs) == 3
    end

    it 'builds a function that can compare using all attributes'
      let t1 = {'source__data': {'project': 'A', 'urgency': 2}}
      let t2 = {'source__data': {'project': 'A', 'urgency': 1}}
      let t3 = {'source__data': {'project': 'B', 'urgency': 1}}
      let t4 = {'source__data': {'project': 'B', 'urgency': 2}}

      let context = {'custom_sorting': 'project-,urgency+'}
      let sorter = unite#filters#sorter_task#build(context)

      Expect sorter.func(t1, t1) == 0
      Expect sorter.func(t1, t2) == 1
      Expect sorter.func(t1, t3) == 1
      Expect sorter.func(t1, t4) == 1
      Expect sorter.func(t2, t1) == -1
      Expect sorter.func(t2, t3) == 1
      Expect sorter.func(t2, t4) == 1
      Expect sorter.func(t3, t4) == -1
    end

    it 'can be used in sort'
      let t1 = {'source__data': {'project': 'A', 'urgency': 2, 'id': 1}}
      let t2 = {'source__data': {'project': 'A', 'urgency': 1, 'id': 2}}
      let t3 = {'source__data': {'project': 'B', 'urgency': 1, 'id': 3}}
      let t4 = {'source__data': {'project': 'B', 'urgency': 2, 'id': 4}}

      let context = {'custom_sorting': 'project-,urgency+'}
      let sorter = unite#filters#sorter_task#build(context)
      let val = sort([t2, t4, t3, t1], sorter.func, sorter)
      Expect val == [t3, t4, t2, t1]
    end

    it 'can sort by date'
      let t1 = {'source__data': {'project': 'A', 'urgency': 2, 'due': '20120110T231200Z'}}
      let t2 = {'source__data': {'project': 'A', 'urgency': 1, 'due': '20120110T231203Z'}}
      let t3 = {'source__data': {'project': 'B', 'urgency': 1, 'due': '20120110T231201Z'}}
      let t4 = {'source__data': {'project': 'B', 'urgency': 2, 'due': '20120110T231200Z'}}

      let context = {'custom_sorting': 'due-'}
      let sorter = unite#filters#sorter_task#build(context)
      let val = sort([t2, t4, t3, t1], sorter.func, sorter)
      Expect val == [t2, t3, t4, t1]
    end
  end
end
