function isLocked()
    local bValue = Funct.ternary(getValue()==1, true, false);
    return bValue;
end