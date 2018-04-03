pragma solidity ^0.4.18;
import './StandardToken.sol';
contract MyToken is StandardToken{
    
    string public constant name = "MyToken";
    string public constant symbol = "MFT";
    uint public constant decimal = 18;
    uint public constant TOTAL_SUPPLY = 1300000000 * (1 ether / 1 wei);
    uint public constant DEVELOPERS_BONUS = 300000000 * (1 ether / 1 wei);
    uint public constant TOTAL_SOLD_TOKEN_SUPPLY_LIMIT = 1000000000* (1 ether / 1 wei);
     uint public totalSoldTokens = 0;
    uint public constant PRICE = 30000;  // per 1 Ether
    uint public supply = 0;
    
   address owner;
    function MyToken() {
        balances[this] = balances[this] + DEVELOPERS_BONUS;
        assert(TOTAL_SOLD_TOKEN_SUPPLY_LIMIT==1000000000 * (1 ether / 1 wei));
        
        owner = msg.sender;
    }
    function buyTokens() public payable
    {
       
       uint newTokens = msg.value * PRICE;
       require(totalSoldTokens + newTokens <= TOTAL_SOLD_TOKEN_SUPPLY_LIMIT);
        supply+= newTokens;
        
        totalSoldTokens+= newTokens;
       balances[this] -= newTokens;
        balances[msg.sender] += newTokens;
        
       
        
       
    }
     modifier onlyOwner(){
        require(msg.sender == owner);
        _;
        
    }
    
    //this 
   
   
    struct BenfeciaryGrant {
        uint value;
        bool revokable;
        uint startTime;
        uint endTime;
        uint cliffTime;
        uint usedTokens;
    }
  mapping(address => BenfeciaryGrant) benfeciaryGrants;
  //total vesting which is already done;
  uint public totalVestedAmount;
  function grantToBeneficiary(uint _value,address _beneficiaryAddress,bool _revokable,uint _startTime,uint _endTime,uint _cliff) onlyOwner
  {
      
     
     
        benfeciaryGrants[_beneficiaryAddress].value = _value;
    
        benfeciaryGrants[_beneficiaryAddress].revokable = _revokable;
        benfeciaryGrants[_beneficiaryAddress].startTime = _startTime;
        benfeciaryGrants[_beneficiaryAddress].endTime = _endTime;
        benfeciaryGrants[_beneficiaryAddress].cliffTime = _cliff;
        totalVestedAmount=+_value;
        balances[_beneficiaryAddress] = + _value;
        balances[this] = - _value;
        
        
        
      
  }
  //calculating vested tokens at any timestamp.
  function CalculateVestedTokens(address _beneficiaryAddress,uint _anyTimeStamp) public constant returns (uint) {
      BenfeciaryGrant grant = benfeciaryGrants[_beneficiaryAddress];
     
      if(grant.value == 0 ){
          return 0;
      }
      if( _anyTimeStamp < grant.cliffTime){
          return 0;
      }
     if (_anyTimeStamp >= grant.endTime) {
            return grant.value;
        }
        uint duration =  grant.endTime.sub(grant.startTime);
        
      
     uint tokensMulTime = grant.value.mul((_anyTimeStamp.sub(grant.startTime)));
    
         
     return tokensMulTime / duration;
      
      
  }
  /// overriden methods

    function transfer(address _to, uint256 _value)  public  returns (bool success) {
        if(benfeciaryGrants[msg.sender].value > 0){
             BenfeciaryGrant grant = benfeciaryGrants[msg.sender];
             require(grant.value != 0);
              uint vestedTokens = CalculateVestedTokens(msg.sender,block.timestamp);
          if(vestedTokens == 0){
              return false;
            }
       
          uint transferableTokens = vestedTokens.sub(grant.usedTokens);
          require(transferableTokens >= _value);
          if(transferableTokens == 0){
              return false;
          }
        
          grant.usedTokens = grant.usedTokens.add(_value);
          totalVestedAmount = totalVestedAmount.sub(_value);
      return super.transfer(_to, _value);
            
        }
        else{
            
             return super.transfer(_to, _value);
        }
        
     
    }

  
  function getCurrentVestedTokens() public constant returns (uint){
      return CalculateVestedTokens(msg.sender,block.timestamp);
  }
  function revokeVesting(address beneficiary) onlyOwner {
      BenfeciaryGrant grant = benfeciaryGrants[beneficiary];
     require(grant.revokable);
     uint refund = grant.value.sub(grant.usedTokens);
     totalVestedAmount = totalVestedAmount.sub(refund);
     transfer(beneficiary,refund);
     
   
      
  }

    
 
    function () payable {
        buyTokens();
    }
    
    function getPrice () public constant returns (uint){
        return PRICE;
    }
    function tokenBalance() public constant returns(uint){
        return balanceOf(this);
        
    }
    }