### Electronic companion of the paper: "Optimal layout of a dining room in the era of COVID-19 using integer programming" by Claudio Contardo (ESG UQAM, Canada, claudio.contardo@gerad.ca) and Luciano Costa (UFPE, Brazil, luciano.ccosta@ufpe.br)

#####  **Example:** julia --project=. src/example.jl

##### **Usage:** julia --project=. src/run_find_layout.jl [--method METHOD] [--plot] [--verbose] [--mindist MINDIST] [--backback] [--tl TL] --instance INSTANCE [-h]

**Optional Arguments**:

    --method METHOD      method to be performed: exact | placeclosecorner | placerandomly. (default: "exact")
    --plot               allows plotting the layout. By default: false
    --verbose            verbose output. By default: false
    --mindist MINDIST    minimum distance allowed between persons (type: Float64, default: 2.0)
    --backback           allow people to sit back to back within less than the minimum distance. By default: false
    --tl TL              time limit (type: Int64, default: 86400)
    --instance INSTANCE  path to instance file
    -h, --help           show this help message and exit
