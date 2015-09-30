describe 'building sorting functions'
  it 'can parse a simple string'
    let attrs = unite#filters#sorter_task#parse('urgency+')
    Expect len(attrs) == 1
  end

  it 'can parse a complex string'
    let attrs = unite#filters#sorter_task#parse('urgency-,due-')
    Expect len(attrs) == 2
  end

  it 'can parse a string with several simple ones'
    let attrs = unite#filters#sorter_task#parse('urgency+,due-,tag+')
    Expect len(attrs) == 3
  end

  it 'stores the attribute to use'
    let attrs = unite#filters#sorter_task#parse('urgency+')
    Expect attrs[0].name == 'urgency'
  end

  it 'gets the ordering as forward if +'
    let attrs = unite#filters#sorter_task#parse('urgency+')
    Expect attrs[0].ordering == 1
  end

  it 'gets the ordering as backward if -'
    let attrs = unite#filters#sorter_task#parse('urgency-')
    Expect attrs[0].ordering == 0
  end
end
