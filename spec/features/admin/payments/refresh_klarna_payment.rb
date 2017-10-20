require 'features_helper'

xdescribe 'Managing a Klarna Payment', type: 'feature', bdd: true do
  include_context "ordering with klarna"
  include WorkflowDriver::Process

  it 'Refresh a Klarna Payment'
end
