pragma solidity ^0.4.18;

contract O {
    event log(string);
    function exec() public {
        log(" O ");
    }
}

contract A is O {
    event log(string);
    function exec() public {
        log(" A ");
        super.exec();
    }
}

contract B is O {
    event log(string);
    function exec() public {
        log(" B ");
        super.exec();
    }
}

contract C is O {
    event log(string);
    function exec() public {
        log(" C ");
        super.exec();
    }
}

contract K1 is A, B {
    event log(string);
    function exec() public {
        log(" K1 ");
        super.exec();
    }
}

contract K2 is A, C {
    event log(string);
    function exec() public {
        log(" K2 ");
        super.exec();
    }
}

contract Z is K1, K2 {
    event log(string);
    function exec() public {
        log(" Z ");
        super.exec();
    }
}