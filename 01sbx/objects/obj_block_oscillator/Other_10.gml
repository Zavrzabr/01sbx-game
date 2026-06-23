// Круговой автомат состояний осциллятора
switch (status) {
    case "ready":
        next_status = "active";
        break;
        
    case "active":
        next_status = "cooldown";
        break;
        
    case "cooldown":
        next_status = "ready";
        break;
}