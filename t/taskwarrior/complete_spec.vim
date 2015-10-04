describe 'complete functions'
  describe 'next status'
    it 'can get next using toggle_mapping'
      let val = unite#taskwarrior#complete#next_status('completed', '', 4)
      Expect val == ['deleted']
    end

    it 'will suggest similar one'
      let val = unite#taskwarrior#complete#next_status('comp', '', 4)
      Expect val == ['completed']
    end

    it 'suggested based on match starting'
      let val = unite#taskwarrior#complete#next_status('p', '', 4)
      Expect val == ['pending']
    end

    it 'will suggest nothing for an unknown status'
      let val = unite#taskwarrior#complete#next_status('coml', '', 4)
      Expect val == []
    end
  end
end
