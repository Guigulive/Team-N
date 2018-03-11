pragma solidity ^0.4.14;
contract Payroll {
    
    uint salary = 1 ether;
    address frank = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    uint constant payDuration = 10 seconds;
    uint lastPayDay = now;
    
    //添加资金 
    function addFund() payable returns (uint){
        return this.balance;
    }
    
    //计算合约balance还能支付的次数 
    function calculateRunway() returns (uint){
        return this.balance / salary;
    }
    
    //是否够发放当前工资 
    function hasEnoughFund() returns (bool){
        return calculateRunway() > 0;
    }
    
    //领取工资 
    function getPaid() returns (uint){
        if(msg.sender != frank){
            revert();
        }
        uint nextPayDay = lastPayDay + payDuration;
        if(nextPayDay > now){
            revert();
        }
        
        lastPayDay = nextPayDay;
        frank.transfer(salary);
    }
    
    //修改地址 注意在remix中调用时参数地址打双引号 ！！
    function changeAddress(address s) returns (address){
        frank = s;
        return frank;
    }
    
    //修改薪酬为5ether   输入 "5000000000000000000"
    function changeFund(uint f) returns (uint){
        salary = f;
        return salary;
    }
    
    
    
}