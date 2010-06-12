pdf.font "#{Rails.root}/public/ipag.ttf"

pdf.text I18n.l(Time.zone.today)
pdf.text "#{params[:name]} 御中"

pdf.move_down 20

pdf.font_size(20) do
pdf.text "資料利用依頼", :align => :center    
end

pdf.move_down 20

pdf.text current_user.library.address, :align => :right
pdf.text "#{current_user.library.display_name.localize}  印", :align => :right
pdf.text current_user.library.telephone_number_1, :align => :right

pdf.move_down 30

pdf.text "以下の資料の利用を申し込みます。"

pdf.move_down 20

pdf.text "資料詳細", :size => 18
pdf.move_down 10
pdf.text "#{@manifestation.original_title} (#{@manifestation.isbn})"

pdf.move_down 20

pdf.text "利用者", :size => 18
pdf.move_down 10
pdf.text current_user.patron.full_name
pdf.text current_user.patron.address_1
pdf.text current_user.patron.telephone_number_1

pdf.move_down 200

pdf.text "※利用者の方へ"
pdf.text "このファイルを印刷の上、所属している図書館で依頼状に印鑑を押してもらってください。"
