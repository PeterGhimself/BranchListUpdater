function getBranchList() {
    groups = document.getElementsByClassName('repo_group');
    roboRepo = null;

    for (let i = 0; i < groups.length; i++) {
        let x = groups[i].innerHTML.split('selected')
        if (x[1]) { // if defined
            console.log(groups[i]);
            console.log(groups[i].innerHTML.split('selected'));

            if (x[1].includes('robotics-prototype')) {
                console.log('found it');
                roboRepo = groups[i];
            }
        }
    }

    return roboRepo.getElementsByClassName('branches')[0].value
}

getBranchList()
