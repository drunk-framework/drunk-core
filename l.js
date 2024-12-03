if (window.location.href.includes("typeracer")) {
    document.addEventListener("keyup", (e) => {
        if (e.key === "Enter") {
            var n=document.querySelectorAll('[unselectable="on"]');var t="";n.forEach(function(n){t+=n.innerHTML});var e=0;document.getElementsByClassName("txtInput")[0].addEventListener("keypress",function(n){n.preventDefault();this.value+=t[e++]});
        }
    })
}