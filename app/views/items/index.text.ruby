title,isbn	item_identifier	call_number	created_at
<%- @items.each do |item| -%>
"<%=h item.manifestation.original_title.gsub(/"/, '""') if item.manifestation -%>"	<%=h item.manifestation.identifier_contents(:isbn).join("; ") %>	<%=h item.item_identifier -%>	<%=h item.call_number -%>	<%=h item.created_at %><%= "\n" -%>
<%- end -%>
