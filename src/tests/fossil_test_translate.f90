!< FOSSIL, test translate STL.

program fossil_test_translate
!< FOSSIL, test translate STL.

use flap, only : command_line_interface
use fossil, only : file_stl_object, surface_stl_object
use penf, only : I4P, R8P
use vecfor, only : ex_R8P, ey_R8P, ez_R8P, vector_R8P

implicit none

type(file_stl_object)    :: file_stl            !< STL file.
type(surface_stl_object) :: surface             !< STL surface.
character(999)           :: file_name_stl       !< Input STL file name.
type(vector_R8P)         :: delta               !< Vectorial delta.
type(vector_R8P)         :: bmin                !< Vectorial bounding box.
type(vector_R8P)         :: bmax                !< Vectorial bounding box.
real(R8P)                :: x, y, z             !< Scalar deltas.
logical                  :: are_tests_passed(6) !< Result of tests check.

are_tests_passed = .false.

call cli_parse
call file_stl%load_from_file(facet=surface%facet, file_name=trim(adjustl(file_name_stl)), guess_format=.true.)
call surface%analize

bmin = surface%bmin
bmax = surface%bmax

call surface%translate(delta=delta)
call file_stl%save_into_file(facet=surface%facet, file_name='fossil_test_translate-delta.stl')
are_tests_passed(1) = nint(surface%distance(point=2 * ex_R8P + 0 * ey_R8P + 0 * ez_R8P)) == 0
call surface%translate(delta=-delta)
call surface%translate(x=x)
are_tests_passed(2) = nint(surface%distance(point=2 * ex_R8P + 0 * ey_R8P + 0 * ez_R8P)) == 0
call surface%translate(y=y)
are_tests_passed(3) = nint(surface%distance(point=2 * ex_R8P + 2 * ey_R8P + 0 * ez_R8P)) == 0
call surface%translate(z=z)
are_tests_passed(4) = nint(surface%distance(point=2 * ex_R8P + 2 * ey_R8P + 2 * ez_R8P)) == 0
call file_stl%save_into_file(facet=surface%facet, file_name='fossil_test_translate-xyz.stl')
are_tests_passed(5) = all(nint(bmin - surface%bmin) == 0) .and. all(nint(bmax - surface%bmax) == 0)
call surface%translate(recompute_metrix=.true.)
are_tests_passed(6) = all(nint(bmin - surface%bmin) /= 0) .and. all(nint(bmax - surface%bmax) /= 0)

print '(A,L1)', 'Are all tests passed? ', all(are_tests_passed)
contains
  subroutine cli_parse()
  !< Build and parse test cli.
  type(command_line_interface) :: cli      !< Test command line interface.
  real(R8P)                    :: delta_(3) !< Vectorial delta.
  integer(I4P)                 :: error    !< Error trapping flag.

  call cli%init(progname='fossil_test_translate',                              &
                authors='S. Zaghi',                                            &
                help='Usage: ',                                                &
                examples=["fossil_test_translate --stl src/tests/dragon.stl"], &
                epilog=new_line('a')//"all done")

  call cli%add(switch='--stl',               &
               help='STL (input) file name', &
               required=.false.,             &
               def='src/tests/cube.stl',     &
               act='store')

  call cli%add(switch='--delta',       &
               help='vectorial delta', &
               required=.false.,       &
               nargs='+',              &
               def='1.0 0.0 0.0',      &
               act='store')

  call cli%add(switch='--x',     &
               help='delta x',   &
               required=.false., &
               def='1.0',        &
               act='store')

  call cli%add(switch='--y',     &
               help='delta y',   &
               required=.false., &
               def='1.0',        &
               act='store')

  call cli%add(switch='--z',     &
               help='delta z',   &
               required=.false., &
               def='1.0',        &
               act='store')

  call cli%parse(error=error) ; if (error/=0) stop

  call cli%get(switch='--stl',   val=file_name_stl, error=error) ; if (error/=0) stop
  call cli%get(switch='--delta', val=delta_,        error=error) ; if (error/=0) stop
  call cli%get(switch='--x',     val=x,             error=error) ; if (error/=0) stop
  call cli%get(switch='--y',     val=y,             error=error) ; if (error/=0) stop
  call cli%get(switch='--z',     val=z,             error=error) ; if (error/=0) stop
  delta%x = delta_(1)
  delta%y = delta_(2)
  delta%z = delta_(3)
  endsubroutine cli_parse
endprogram fossil_test_translate
