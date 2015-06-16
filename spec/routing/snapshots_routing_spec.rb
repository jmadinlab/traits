require "spec_helper"

describe SnapshotsController do
  describe "routing" do

    it "routes to #index" do
      get("/snapshots").should route_to("snapshots#index")
    end

    it "routes to #new" do
      get("/snapshots/new").should route_to("snapshots#new")
    end

    it "routes to #show" do
      get("/snapshots/1").should route_to("snapshots#show", :id => "1")
    end

    it "routes to #edit" do
      get("/snapshots/1/edit").should route_to("snapshots#edit", :id => "1")
    end

    it "routes to #create" do
      post("/snapshots").should route_to("snapshots#create")
    end

    it "routes to #update" do
      put("/snapshots/1").should route_to("snapshots#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/snapshots/1").should route_to("snapshots#destroy", :id => "1")
    end

  end
end
