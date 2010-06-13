xml.instruct! :xml, :version=>"1.0" , :encoding => 'Shift_JIS'
xml.CRD('version' => "1.0"){
  @questions.each do |question|
    xml.REFERENCE{
      xml.QUESTION h(question.body)
      xml.tag! 'ACC-LEVEL', '1'
      xml.tag! 'REG-ID', "#{LibraryGroup.site_config.name}_#{question.id}"
      xml.ANSWER h(question.answers.first.try(:body))
      xml.tag! 'CRT-DATE', h(question.created_at.strftime('%Y%m%d'))
      if question.solved?
        xml.SOLUTION 1
      else
        xml.SOLUTION 0
      end
      # xml.KEYWORD question.tags.collect(&:name).join(' ')
      xml.KEYWORD h(question.tags.join(' '))
      xml.CLASS :type => 'NDC'
      xml.tag! 'RES-TYPE'
      xml.tag! 'CON-TYPE'
      question.answers.each do
        xml.BIBL{
          xml.tag! 'BIBL-DESC'
          xml.tag! 'BIBL-NOTE'
        }
      end
      xml.tag! 'ANS-PROC', h(question.answers.first.try(:body))
      xml.REFERRAL
      xml.tag! 'PRE-RES'
      xml.NOTE h(question.note)
      xml.tag! 'PTN-TYPE'
      if question.answers.first
        xml.CONTRI question.answers.collect(&:user).collect(&:username).uniq.join(' ')
      end
    }
  end
}
