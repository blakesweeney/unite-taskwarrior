describe 'sorting functions'
  describe 'simple functions'
    it 'it can compare forward'
      let attrs = unite#filters#sorter_task#parse('urgency+')
      let attr = attrs[0]
      let t1 = {'urgency': 2}
      let t2 = {'urgency': 1}
      Expect attr.func(attr.name, t1, t2, attr.ordering) == 1
      Expect attr.func(attr.name, t2, t1, attr.ordering) == -1
      Expect attr.func(attr.name, t1, t1, attr.ordering) == 0
      Expect attr.func(attr.name, t2, t2, attr.ordering) == 0
    end

    it 'it can compare backward'
      let attrs = unite#filters#sorter_task#parse('urgency-')
      let attr = attrs[0]
      let t1 = {'urgency': 2}
      let t2 = {'urgency': 1}
      Expect attr.func(attr.name, t1, t2, attr.ordering) == -1
      Expect attr.func(attr.name, t2, t1, attr.ordering) == 1
      Expect attr.func(attr.name, t1, t1, attr.ordering) == 0
      Expect attr.func(attr.name, t2, t2, attr.ordering) == 0
    end

    it 'will not fail if attribute is missing'
      let attrs = unite#filters#sorter_task#parse('urgency-')
      let attr = attrs[0]
      Expect attr.func(attr.name, {}, {}, attr.ordering) == 0
    end
  end

  describe 'functions on lists'
    it 'can compare foward'
      let attrs = unite#filters#sorter_task#parse('depends+')
      let attr = attrs[0]
      let t1 = {'depends': [3, 4, 5]}
      let t2 = {'depends': [1, 2]}
      Expect attr.func(attr.name, t1, t2, attr.ordering) == 1
      Expect attr.func(attr.name, t2, t1, attr.ordering) == -1
      Expect attr.func(attr.name, t1, t1, attr.ordering) == 0
      Expect attr.func(attr.name, t2, t2, attr.ordering) == 0
    end
  end

end
