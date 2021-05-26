module jlookc

using DelimitedFiles
export loadCompactLooks
export readCompactLooks
export formOneLook
export formAllLooks

#' Load result of saveCompactLooks
#'
function loadCompactLooks(savepath, filetype = "csv")
  looks = Dict([
    ("knockoffs", Nothing),
    ("groups", Nothing),
    ("vars_to_omit", []),
    ("updates", [])
  ])
  if filetype == "csv"
    function do_load( thing )
      my_file = joinpath( savepath, thing * "." * filetype )
      return readdlm(my_file, ',', header = true)[1]
    end
  elseif filetype == "h5"
    throw(DomainError("Reading hdf5 is not implemented yet.\n"))
  else
    throw(DomainError("Filetype must be 'csv' or 'h5'.\n"))
  end
  
  # Get stuff
  looks["vars_to_omit"] = do_load( "vars_to_omit") 
  looks["knockoffs"] = do_load( "knockoffs" )
  # Handle irregular shape of groups and possible NULL specification of groups
  looks["groups"] = [[parse(Int64, i) for i in split(s, " ")] for s in do_load( "groups") ]
  if length(looks["groups"])==0
    looks["groups"] = Nothing
  end
  
  # Get updates as matrices
  temp = Dict()
  for field in [
    "mean_update_left",
    "mean_update_right",
    "sqrt_cov_update",
    "random_update"
  ]
    temp[field] = do_load( field )
  end
  # Reshape updates into the admittedly eccentric original format
  function fix_transpose(named_updates)
    for n in keys(named_updates)
      if occursin("right", n) | occursin("cov", n)
        named_updates[n] = named_updates[n]'
      end
    end
    return named_updates
  end
  
  looks["updates"] = [Dict() for k in looks["vars_to_omit"]]
  for k in 1:length(looks["vars_to_omit"])
    looks["updates"][k] = fix_transpose(Dict(n => temp[n][:,[k]] for n in keys(temp))) 
  end
  return looks
end

#' Alias for loadCompactLooks
#'
readCompactLooks = loadCompactLooks


#' Extract one update from the low-rank representation, while handling a tricky case properly.
#'
function getUpdateK(k, vars_to_omit, updates)
  correct_index = [i for i in 1:length(vars_to_omit) if vars_to_omit[i]==k][1]  # Handle case when vars_to_omit is not 1, 2, ... P
  return updates[correct_index]
end

#' Given the low-rank representations, update knockoffs to omit each variable.
#'
#' @param k variable to omit.
#' @param updates @param knockoffs @param vars_to_omit
#' Inputs should be from \code{loadCompactLooks} or from \code{generateLooks(..., output_type = 'knockoffs_compact'}.)
#' Those functions return a list with the same names as the necessary args.
#' @export
#'
function formAllLooks(knockoffs, vars_to_omit, updates)
    return [ formOneLook(knockoffs, vars_to_omit, updates, k) for k in vars_to_omit ] 
end


#' Given the low-rank representations, update knockoffs to omit one variable.
#'
#' @param k variable to omit.
#' @param updates @param knockoffs @param vars_to_omit
#' Inputs should be from \code{loadCompactLooks} or from \code{generateLooks(..., output_type = 'knockoffs_compact'}.)
#' Those functions return a list with the same names as the necessary args.
#' @export
#'
function formOneLook(knockoffs, vars_to_omit, updates, k)
  one_update = getUpdateK(k, vars_to_omit, updates)
  mask = [true for i in 1:size(knockoffs)[2]]
  mask[Int64(k)] = false
  return knockoffs[:,mask] + 
           getMeanUpdate(one_update) + 
           getRandomUpdate(one_update)
end

#' Output can be added to knockoffs to correct for removal of a variable.
#'
function getMeanUpdate(updates)
  return updates["mean_update_left"] * updates["mean_update_right"] 
end

function getRandomUpdate(updates)
  return updates["random_update"] * updates["sqrt_cov_update"]
end



end
