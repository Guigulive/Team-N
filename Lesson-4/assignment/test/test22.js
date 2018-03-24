var Payroll = artifacts.require("./Payroll.sol");


contract('Payroll', function (accounts) {
    owner = accounts[0];
    // addEmployee
    it("add employee successfully", function () {
        return Payroll.deployed().then(function (instance) {
            payrollinstance = instance;
            return payrollinstance.addEmployee(accounts[1], 1);
        }).then(function () {
            return payrollinstance.employees.call(accounts[1]);
        }).then(function (employee) {
            employee1 = employee[0];
        }).then(function () {
            return payrollinstance.addEmployee(accounts[2], 2);
        }).then(function () {
            return payrollinstance.employees.call(accounts[2]);
        }).then(function (employee) {
            employee2 = employee[0];
        }).then(function () {
            assert.equal(employee1, accounts[1]);
            assert.equal(employee2, accounts[2]);
            
        });
    });
    
    // addEmployee by nonowner   
    it("add employee by nonowner failed", function () {
        return Payroll.deployed().then(function (instance) {
            payrollinstance = instance;
            exception = false;
            return payrollinstance.addEmployee(accounts[1], 1, { from: accounts[1] });
        }).catch(function (error) {
            exception = true;
        }).then(function () {
            assert.equal(exception, true);
        });
    });

    // removeEmployee 
    it("remove employee successfully", function () {
        return Payroll.deployed().then(function (instance) {
            payrollinstance = instance;
            amount = web3.toWei(9, "ether")
            return payrollinstance.addFund({ from: owner, value: amount });
        }).then(function () {
            return payrollinstance.addEmployee(accounts[1], 1);
        }).then(function () {
            return payrollinstance.employees.call(accounts[1]);
        }).then(function (employee) {
            employee1 = employee[0];
        }).then(function () {
            return payrollinstance.removeEmployee(accounts[1]);
        }).then(function () {
            return payrollinstance.employees.call(accounts[1]);
        }).then(function (employee) {
            employee2 = employee[0];
        }).then(function () {
            assert(employee1, accounts[1]);
            assert(employee2, 0);
        });
    });

    // removeEmployee by nonowner
    it("remove employee by nonowner failed", function () {
        return Payroll.deployed().then(function (instance) {
            payrollinstance = instance;
            exception = false;
            return payrollinstance.addEmployee(accounts[1], 1);
        }).then(function () {
            return payrollinstance.removeEmployee(accounts[1], { from: accounts[2] });
        }).catch(function (error) {
            exception = true;
        }).then(function () {
            assert.equal(exception, true);
        });
    });

    //removeEmployee not existing
    it("remove employee not existing failed", function () {
        return Payroll.deployed().then(function (instance) {
            payrollinstance = instance;
            exception = false;
            return payrollinstance.addEmployee(accounts[1], 1);
        }).then(function () {
            return payrollinstance.removeEmployee(accounts[3]);
        }).catch(function (error) {
            exception = true;
        }).then(function () {
            assert.equal(exception, true);
        });
    });

});
