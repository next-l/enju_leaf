module MyAccountHelper
  def otp_barcode(issuer = @library_group.display_name)
    label = "#{issuer}:#{current_user.username}"
    barcode = Barby::QrCode.new(current_user.otp_provisioning_uri(label, issuer: issuer))
    image_tag("data:image/png;base64,#{Base64.encode64(barcode.to_png(xdim: 3))}")
  end
end
