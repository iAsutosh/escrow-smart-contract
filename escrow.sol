// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.7.0;

// Defining a Contract 
contract escrow{ 
  
    // Declaring the state variables 
    address payable public buyer; 
    address payable public seller; 
    address payable public judge;
    uint public disputeTime;
    uint public disputeFee;
    uint256 public holdBalance;
    uint public expiryTime;
    mapping(address => uint256) public funds;
    mapping(address => uint) public expiryOfDispute;
    
    //events
    
  
    // Defining a enumerator 'State' 
    enum State{ 
         
        // Following are the data members 
        AWATE_PAYMNET,
        PAY_TO_CONTRACT,
        AWAIT_FOR_DISPUTE,
        DISPUTE_RAISED,
        SELLER_PAID_FEE,
        COMPLETE  
    } 
  
    // Declaring the object of the enumerator 
    State public state; 
      
    // Defining function modifier 'instate' 
    modifier instate(State expected_state){ 
        require(state == expected_state); 
        _; 
    } 
    //Defining function modifier 'onlyJudge'
    modifier onlyJudge(){
        require(msg.sender == judge);
        _;
    }
  
   // Defining function modifier 'onlyBuyer' 
    modifier onlyBuyer(){ 
        require(msg.sender == buyer); 
        _; 
    } 
  
    // Defining function modifier 'onlySeller' 
    modifier onlySeller(){ 
        require(msg.sender == seller); 
        _; 
    }
    //modifier function to remove dispute expiryOfDispute
    //after expiry time
    // modifier removeExpiry(){
        
    // }
    
    // Defining a constructor 
    constructor(address payable _buyer,  
                address payable _seller,uint _disputeTime,uint256 _disputeFee) public{ 
        
        // Assigning the values of the  
        // state variables 
        judge = msg.sender; 
        buyer = _buyer; 
        seller = _seller; 
        state = State.AWATE_PAYMNET;
        disputeTime = _disputeTime;
        disputeFee = _disputeFee;
    }
      
    // Defining function to confirm payment 
    function payment() onlyBuyer payable public { 
        state = State.PAY_TO_CONTRACT;
        holdBalance = msg.value;
        funds[seller]=msg.value;
        state = State.COMPLETE;
        expiryTime = now + disputeTime;
    }
    
  
    // Raise dispute before expiry time
    function raise_dispute_buyer() onlyBuyer payable public returns (bool sucess){
        require(now < expiryTime);
        if(msg.value >= disputeFee) return false;
        state = State.DISPUTE_RAISED;
        funds[judge] = funds[judge]+ msg.value;
        return true;
    }
    
    //seller will pay fee for dispute decision
    function pay_fee_seller () onlySeller payable public returns (bool sucess){
        if(msg.value >= disputeFee) return false;
        state = State.SELLER_PAID_FEE;
        funds[judge] = funds[judge]+ msg.value;
        return true;
    }
    
    //judge will refund_to_buyer if seller refure to pay dispute fee
    function refund_to_buyer () onlyJudge payable public {
        buyer.send(holdBalance+disputeFee);
        funds[judge] = funds[judge] - disputeFee;
        funds[seller] = funds[seller] - holdBalance;
        holdBalance = 0;
        state = State.AWATE_PAYMNET;
        expiryOfDispute[seller] = 0;
    }
    
    //judge will give decision passing winner address
    function give_decision(address winner) onlyJudge public {
        if(buyer == winner){
            buyer.send(holdBalance);
            
        }
        holdBalance = 0;
        state = State.COMPLETE;
        expiryOfDispute[seller] = 0;
    }
    // Define function to withdraw ether
    // seller can withdraw finds
    // while seller withdraw we will check any expiry time is present or not.
    function withdraw () onlySeller  payable public {
        require(now > expiryTime);
        msg.sender.send(funds[msg.sender]);
        funds[msg.sender] = 0;
    }
    //withdraw fee only judge can withdraw 
     function withdraw_fees () onlyJudge  payable public {
        require(expiryOfDispute[seller] == 0);
        msg.sender.send(funds[msg.sender]);
        funds[msg.sender] = 0;
    }
} 
