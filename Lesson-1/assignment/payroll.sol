pragma solidity ^0.4.14;
contract Payroll {
    
    uint salary = 1 ether;
    uint constant payDuration = 10 seconds;
    uint lastPayDay = now;
    address employeeAddr = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    address adminAddr = 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db; //先给管理员写死一个地址  
    
    //给部分function加管理员权限 
    modifier onlyAdmin(){
        require(msg.sender == adminAddr);
        _;
    }
    
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
        if(msg.sender != employeeAddr){
            revert();
        }
        uint nextPayDay = lastPayDay + payDuration;
        if(nextPayDay > now){
            revert();
        }
        
        lastPayDay = nextPayDay;
        employeeAddr.transfer(salary);
    }
    
    //修改地址 注意在remix中调用时参数地址打双引号 ！！
    function changeAddress(address s)  onlyAdmin returns (address){
        employeeAddr = s;
        return employeeAddr;
    }
    
    //修改薪酬为5ether   输入 "5000000000000000000"
    function changeFund(uint f) onlyAdmin returns (uint){
        salary = f;
        return salary;
    }
    
    
    
}