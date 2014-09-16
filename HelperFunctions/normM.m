function normM = normM(inMatrix)
    minM = min(min(inMatrix));
    maxM = max(max(inMatrix));
    normM = (inMatrix - minM)./(maxM - minM);
end