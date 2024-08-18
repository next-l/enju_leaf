module MyAccountHelper
  def otp_barcode(user = current_user, issuer = @library_group.display_name.localize)
    qrcode = RQRCode::QRCode.new(current_user.otp_provisioning_uri(user.username, issuer: issuer))
    image_tag("data:image/png;base64,#{Base64.encode64(qrcode.as_png(
      bit_depth: 1,
      size: 240,
      module_px_size: 12
    ).to_s)}")
  end
end
