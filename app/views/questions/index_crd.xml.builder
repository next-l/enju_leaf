xml.instruct! :xml, :version=>"1.0" , :encoding => 'Shift_JIS'
xml.CRD('version' => "1.0"){
  @questions.each do |question|
    xml.REFERENCE{
      xml.QUESTION question.body
      xml.tag! 'ACC-LEVEL', '1'
      xml.tag! 'REG-ID', "#{LibraryGroup.site_config.name}_#{question.id}"
      xml.ANSWER question.answers.first.try(:body)
      xml.tag! 'CRT-DATE', question.created_at.strftime('%Y%m%d')
      if question.solved?
        xml.SOLUTION 1
      else
        xml.SOLUTION 0
      end
      # xml.KEYWORD question.tags.collect(&:name).join(' ')
      xml.KEYWORD question.tags.join(' ')
      xml.CLASS :type => 'NDC'
      xml.tag! 'RES-TYPE'
      xml.tag! 'CON-TYPE'
      question.answers.each do
        xml.BIBL{
          xml.tag! 'BIBL-DESC'
          xml.tag! 'BIBL-NOTE'
        }
      end
      xml.tag! 'ANS-PROC', question.answers.first.try(:body)
      xml.REFERRAL
      xml.tag! 'PRE-RES'
      xml.NOTE question.note
      xml.tag! 'PTN-TYPE'
      if question.answers.exists?
        xml.CONTRI question.answers.collect(&:user).collect(&:username).uniq.join(' ')
      end
    }
  end
}
