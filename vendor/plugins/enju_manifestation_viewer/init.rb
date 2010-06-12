require 'enju_manifestation_viewer'
ActiveRecord::Base.send :include, EnjuManifestationViewer
ActionView::Base.send :include, EnjuManifestationViewerHelper
