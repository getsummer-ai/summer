# frozen_string_literal: true
# This controller has been generated to enable Rails' resource routes.
# More information on https://docs.avohq.io/2.0/controllers.html
module Avo
  class ProjectUrlsController < Avo::ResourcesController

    def update
      @record.start_tracking(author: _current_user, source: 'Admin Actions')
      super
    end
  end
end
