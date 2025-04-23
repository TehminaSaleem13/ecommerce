class DashboardController < ApplicationController
  include ProductFilterable
  before_action :authenticate_user!, except: [:index]
  include CartManagement

  
end