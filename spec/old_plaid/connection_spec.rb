describe OldPlaid::Connection do
  let(:stub_url) { "https://tartan.plaid.com/testing" }
  let(:bad_req_response) {  {"code" => 1005, "message" => "invalid credentials", "resolve" => "The username or password provided is not correct."}.to_json }
  let(:unauth_response) { {"code" => 1105, "message" => "bad access_token", "resolve" => "This access_token appears to be corrupted."}.to_json }
  let(:req_fail_response) {  {"code" => 1200, "message" => "invalid credentials", "resolve" => "The username or password provided is not correct."}.to_json }
  let(:req_not_found) {  {"code" =>  1600, "message" => "product not found", "resolve" => "This product doesn't exist yet, we're actually not sure how you reached this error..."}.to_json }

  describe "#post" do
    it "sends a post request" do
      stub = stub_request(:post, stub_url).to_return({:body => {"response" => "OK"}.to_json})
      OldPlaid::Connection.post("testing")
      expect(stub).to have_requested(:post, stub_url)
    end

    it "returns response on 200 response" do
      stub = stub_request(:post, stub_url).to_return({:body => {"response" => "OK"}.to_json})
      response = OldPlaid::Connection.post("testing")
      expect(response).to eq({"response" => "OK"})
    end

    it "returns message on 201 response" do
      stub = stub_request(:post, stub_url).to_return(status: 201, body: {"response" => "OK"}.to_json)
      response = OldPlaid::Connection.post("testing")
      expect(response).to eq({:msg => "Requires further authentication", :body => {"response" => "OK"}})
    end

    it "throws OldPlaid::BadRequest on 400 response" do
      stub = stub_request(:post, stub_url).to_return(status: 400, body: bad_req_response)
      expect { OldPlaid::Connection.post("testing") }.to raise_error(OldPlaid::BadRequest, "invalid credentials")
    end

    it "throws OldPlaid::Unauthorized on 401 response" do
      stub = stub_request(:post, stub_url).to_return(status: 401, body: unauth_response)
      expect { OldPlaid::Connection.post("testing") }.to raise_error(OldPlaid::Unauthorized, "bad access_token")
    end

    it "throws OldPlaid::RequestFailed on 402 response" do
      stub = stub_request(:post, stub_url).to_return(status: 402, body: req_fail_response)
      expect { OldPlaid::Connection.post("testing") }.to raise_error(OldPlaid::RequestFailed, "invalid credentials")
    end

    it "throws a OldPlaid::NotFound on 404 response" do
      stub = stub_request(:post, stub_url).to_return(status: 404, body: req_not_found)
      expect { OldPlaid::Connection.post("testing") }.to raise_error(OldPlaid::NotFound, "product not found")
    end

    it "throws a OldPlaid::ServerError on empty response" do
      stub = stub_request(:post, stub_url).to_return(status: 504, body: '')
      expect { OldPlaid::Connection.post("testing") }.to raise_error(OldPlaid::ServerError, '')
    end
  end

  describe "#get" do
    it "sends a get request" do
      stub = stub_request(:get, stub_url).to_return({:body => {"response" => "OK"}.to_json})
      OldPlaid::Connection.get("testing")
      expect(stub).to have_requested(:get, stub_url)
    end

    it "returns response when no code available" do
      stub = stub_request(:get, stub_url).to_return({:body => {"response" => "OK"}.to_json})
      response = OldPlaid::Connection.get("testing")
      expect(response).to eq({"response" => "OK"})
    end

    it "returns response when code not [1301, 1401, 1501, 1601]" do
      stub = stub_request(:get, stub_url).to_return({:body => {"code" => 1502, "response" => "OK"}.to_json})
      response = OldPlaid::Connection.get("testing")
      expect(response).to eq({"code" => 1502, "response" => "OK"})
    end

    it "throws 404 for 1301 code" do
      stub = stub_request(:get, stub_url).to_return({:body => {"code" => 1301, "message" => "Doesn't matter", "resolve" => "Yep."}.to_json})
      expect { OldPlaid::Connection.get("testing")}.to raise_error(OldPlaid::NotFound, "Doesn't matter")
    end

    it "throws 404 for 1401 code" do
      stub = stub_request(:get, stub_url).to_return({:body => {"code" => 1401, "message" => "Doesn't matter", "resolve" => "Yep."}.to_json})
      expect { OldPlaid::Connection.get("testing")}.to raise_error(OldPlaid::NotFound, "Doesn't matter")
    end

    it "throws 404 for 1501 code" do
      stub = stub_request(:get, stub_url).to_return({:body => {"code" => 1501, "message" => "Doesn't matter", "resolve" => "Yep."}.to_json})
      expect { OldPlaid::Connection.get("testing")}.to raise_error(OldPlaid::NotFound, "Doesn't matter")
    end

    it "throws 404 for 1601 code" do
      stub = stub_request(:get, stub_url).to_return({:body => {"code" => 1601, "message" => "Doesn't matter", "resolve" => "Yep."}.to_json})
      expect { OldPlaid::Connection.get("testing")}.to raise_error(OldPlaid::NotFound, "Doesn't matter")
    end

  end

  describe "#secure_get" do
    it "sends a secure get request" do
      stub = stub_request(:get, stub_url).to_return({:body => {"response" => "OK"}.to_json})
      OldPlaid::Connection.secure_get("testing", "test_wells")
      expect(stub).to have_requested(:get, stub_url).with(:body => {:access_token => "test_wells"})
    end

    it "returns response on 200 response" do
      stub = stub_request(:get, stub_url).to_return({:body => {"response" => "OK"}.to_json})
      response = OldPlaid::Connection.secure_get("testing", "test_wells")
      expect(response).to eq({"response" => "OK"})
    end

    it "returns message on 201 response" do
      stub = stub_request(:get, stub_url).to_return(status: 201, body: {"response" => "OK"}.to_json)
      response = OldPlaid::Connection.secure_get("testing", "test_wells")
      expect(response).to eq({:msg => "Requires further authentication", :body => {"response" => "OK"}})
    end

    it "throws OldPlaid::BadRequest on 400 response" do
      stub = stub_request(:get, stub_url).to_return(status: 400, body: bad_req_response)
      expect { OldPlaid::Connection.secure_get("testing", "test_wells") }.to raise_error(OldPlaid::BadRequest, "invalid credentials")
    end

    it "throws OldPlaid::Unauthorized on 401 response" do
      stub = stub_request(:get, stub_url).to_return(status: 401, body: unauth_response)
      expect { OldPlaid::Connection.secure_get("testing", "test_wells") }.to raise_error(OldPlaid::Unauthorized, "bad access_token")
    end

    it "throws OldPlaid::RequestFailed on 402 response" do
      stub = stub_request(:get, stub_url).to_return(status: 402, body: req_fail_response)
      expect { OldPlaid::Connection.secure_get("testing", "test_wells") }.to raise_error(OldPlaid::RequestFailed, "invalid credentials")
    end

    it "throws a OldPlaid::NotFound on 404 response" do
      stub = stub_request(:get, stub_url).to_return(status: 404, body: req_not_found)
      expect { OldPlaid::Connection.secure_get("testing", "test_wells") }.to raise_error(OldPlaid::NotFound, "product not found")
    end

    it "throws a OldPlaid::ServerError on empty response" do
      stub = stub_request(:get, stub_url).to_return(status: 504, body: '')
      expect { OldPlaid::Connection.secure_get("testing", "test_wells") }.to raise_error(OldPlaid::ServerError, '')
    end
  end

  describe "#patch" do
    it "sends a patch request" do
      stub = stub_request(:patch, stub_url).to_return({:body => {"response" => "OK"}.to_json})
      OldPlaid::Connection.patch("testing")
      expect(stub).to have_requested(:patch, stub_url)
    end

    it "returns response on 200 response" do
      stub = stub_request(:patch, stub_url).to_return({:body => {"response" => "OK"}.to_json})
      response = OldPlaid::Connection.patch("testing")
      expect(response).to eq({"response" => "OK"})
    end

    it "returns message on 201 response" do
      stub = stub_request(:patch, stub_url).to_return(status: 201, body: {"response" => "OK"}.to_json)
      response = OldPlaid::Connection.patch("testing")
      expect(response).to eq({:msg => "Requires further authentication", :body => {"response" => "OK"}})
    end

    it "throws OldPlaid::BadRequest on 400 response" do
      stub = stub_request(:patch, stub_url).to_return(status: 400, body: bad_req_response)
      expect { OldPlaid::Connection.patch("testing") }.to raise_error(OldPlaid::BadRequest, "invalid credentials")
    end

    it "throws OldPlaid::Unauthorized on 401 response" do
      stub = stub_request(:patch, stub_url).to_return(status: 401, body: unauth_response)
      expect { OldPlaid::Connection.patch("testing") }.to raise_error(OldPlaid::Unauthorized, "bad access_token")
    end

    it "throws OldPlaid::RequestFailed on 402 response" do
      stub = stub_request(:patch, stub_url).to_return(status: 402, body: req_fail_response)
      expect { OldPlaid::Connection.patch("testing") }.to raise_error(OldPlaid::RequestFailed, "invalid credentials")
    end

    it "throws a OldPlaid::NotFound on 404 response" do
      stub = stub_request(:patch, stub_url).to_return(status: 404, body: req_not_found)
      expect { OldPlaid::Connection.patch("testing") }.to raise_error(OldPlaid::NotFound, "product not found")
    end

    it "throws a OldPlaid::ServerError on empty response" do
      stub = stub_request(:patch, stub_url).to_return(status: 504, body: '')
      expect { OldPlaid::Connection.patch("testing") }.to raise_error(OldPlaid::ServerError, '')
    end
  end

  describe "#delete" do
    it "sends a delete request" do
      stub = stub_request(:delete, stub_url)
      OldPlaid::Connection.delete("testing")
      expect(stub).to have_requested(:delete, stub_url)
    end
  end
end