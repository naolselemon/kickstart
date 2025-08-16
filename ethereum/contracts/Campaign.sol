
contract CampaignFactory{
    address[] public deployedCampaigns;

    function createCampaign(uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns(address[]){
        return deployedCampaigns;
    }
    
}

contract Campaign{

    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCounts;
        mapping(address => bool) approvals;
    }

    Request[] requests;
    address public manager;
    uint public minimumContribution;
    uint aprroversCount = 0;
    mapping(address => bool) approvers;


    modifier  restricted {
        require (msg.sender == manager);
        _;
    }

    function Campaign(uint minimum, address creator) public {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution);
        approvers[msg.sender] = true;
        aprroversCount++;
    }

    function createRequest(string description, uint value, address recipient) public restricted {
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCounts: 0
        });

        requests.push(newRequest);
    }

    function approvalRequest(uint index)public {
        Request storage request = requests[index];

        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);
        request.approvals[msg.sender] = true;
        request.approvalCounts++;
    }

    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];
        require(request.approvalCounts > aprroversCount / 2);
        require(!request.complete);
        request.recipient.transfer(request.value);
        request.complete = true;
    }
}