// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdFunding {
    string public name;
    string public description;
    uint256 public goal;
    uint256 public deadline;
    address public owner;

    enum CampaignState{Active,Successful,Failed}
    CampaignState public state;
    struct Tier{
        string name;
        uint256 amount;
        uint256 backers;
    }
    Tier[] public tiers;
    modifier onlyOwner(){
        require(msg.sender == owner,"not the owner");
        _;
    }
    modifier  campaignOpen(){
        require(state == CampaignState.Active,"Campaign is not active");
        _;
    }
    constructor(
        string memory _name,
        string memory _description,
        uint256 _goal,
        uint256 _durationInDays
    ) {
        name = _name;
        description=_description;
        goal=_goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
        owner = msg.sender;
        state = CampaignState.Active;
    }
    function checkAndUpdateCampaignState() internal {
        if (state == CampaignState.Active){
            if (block.timestamp >= deadline){
                state = address(this).balance >= goal ? CampaignState.Successful : CampaignState.Failed;}
            else {
                state = address(this).balance >= goal ? CampaignState.Successful : CampaignState.Active;
        }
        }
        
    }
    function fund(uint256 _tierIndex) public payable campaignOpen {
        
        require(_tierIndex < tiers.length,"Invalid tier");
        require(msg.value == tiers[_tierIndex].amount,"incorrect amount");
        tiers[_tierIndex].backers ++;
        checkAndUpdateCampaignState();

    } 
    function addTier(string memory _name,uint256 _amount) public onlyOwner {
        require(_amount > 0,"amount must be greater than 0");
        tiers.push(Tier(_name,_amount,0));
    }
    function removeTier(uint256 _index) public onlyOwner {
        require(_index < tiers.length,"Tier does not exist");
        
        tiers[_index] = tiers[tiers.length -1];
        
        tiers.pop();
    }
    function withdraw() public onlyOwner {
        //require(msg.sender == owner,"only the owner can withdraw.");
        checkAndUpdateCampaignState();
        require(state == CampaignState.Successful,"Campaign is not succeful");
        uint256 balance = address(this).balance;
        require(balance > 0,"no balance to witdraw");
        payable (owner).transfer(balance); 
    }
     
    
    function getContractBalance() public view returns (uint256){
        return address(this).balance;
    }
    
}